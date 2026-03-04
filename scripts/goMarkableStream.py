#!/usr/bin/env python3
# goMarkableStream launcher for reMarkable 2 on Windows
#
# Starts goMarkableStream on the reMarkable device on-demand and opens
# the stream in the default browser. Kills the process on exit.
#
# Requirements: pip install paramiko
#
# Usage:
#   python goMarkableStream.py          # start streaming
#   python goMarkableStream.py --stop   # stop goMarkableStream on the tablet
#
# Environment variables:
#   REMARKABLE_IP  - IP address of the reMarkable (default: 10.11.99.1)
#   GMS_PORT       - Port goMarkableStream listens on (default: 2001)

import argparse
import os
import signal
import subprocess
import sys
import time

import paramiko

REMARKABLE_IP = os.environ.get("REMARKABLE_IP", "10.11.99.1")
GMS_PORT = int(os.environ.get("GMS_PORT", "2001"))


def create_ssh_client():
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(
        REMARKABLE_IP,
        username="root",
        look_for_keys=True,
        allow_agent=True,
    )
    return client


def kill_gms(client):
    _, stdout, _ = client.exec_command("kill -9 $(pidof goMarkableStream) 2>/dev/null; true")
    stdout.channel.recv_exit_status()


def is_running(client):
    _, stdout, _ = client.exec_command("pidof goMarkableStream")
    return bool(stdout.read().decode().strip())


def start_gms(client):
    client.exec_command("nohup ~/goMarkableStream > /tmp/gms.log 2>&1 &")


def main():
    parser = argparse.ArgumentParser(description="goMarkableStream launcher for reMarkable 2")
    parser.add_argument("--stop", action="store_true", help="stop goMarkableStream on the tablet")
    args = parser.parse_args()

    print(f"Connecting to reMarkable at {REMARKABLE_IP}...")
    try:
        client = create_ssh_client()
    except Exception as e:
        print(f"Cannot connect to reMarkable at {REMARKABLE_IP}. Is it plugged in?\n{e}")
        sys.exit(1)

    if args.stop:
        print("Stopping goMarkableStream on reMarkable...")
        kill_gms(client)
        time.sleep(1)
        status = "RUNNING" if is_running(client) else "STOPPED"
        print(f"goMarkableStream is {status}")
        client.close()
        return

    # Kill any leftover process from a previous session
    kill_gms(client)

    # Start goMarkableStream on the device
    start_gms(client)
    print("Starting goMarkableStream...")
    time.sleep(2)

    # Open the stream in the default browser
    url = f"https://{REMARKABLE_IP}:{GMS_PORT}"
    subprocess.run(["start", url], shell=True)
    print(f"Streaming at {url} (credentials: admin / password)")
    print("Press Ctrl+C to stop...")

    # Kill goMarkableStream on the device on exit
    def cleanup(signum=None, frame=None):
        print("\nStopping goMarkableStream on reMarkable...")
        try:
            kill_gms(client)
        except Exception:
            pass
        client.close()
        sys.exit(0)

    signal.signal(signal.SIGINT, cleanup)
    signal.signal(signal.SIGTERM, cleanup)

    while True:
        time.sleep(1)


if __name__ == "__main__":
    main()
