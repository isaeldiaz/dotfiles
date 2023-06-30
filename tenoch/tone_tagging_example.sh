cover.jpg
De 39 trinn - Cd 01 Track 01.mp3
De 39 trinn - Cd 01 Track 02.mp3
De 39 trinn - Cd 01 Track 03.mp3
De 39 trinn - Cd 01 Track 04.mp3
De 39 trinn - Cd 01 Track 05.mp3
De 39 trinn - Cd 01 Track 06.mp3
De 39 trinn - Cd 01 Track 07.mp3
De 39 trinn - Cd 01 Track 08.mp3
De 39 trinn - Cd 01 Track 09.mp3
De 39 trinn - Cd 01 Track 10.mp3
De 39 trinn - Cd 02 Track 01.mp3
De 39 trinn - Cd 02 Track 02.mp3
De 39 trinn - Cd 02 Track 03.mp3
De 39 trinn - Cd 02 Track 04.mp3

tone tag \
  --meta-album "De 39 Trinn" \
  --meta-genre "Audiobook" \
  --meta-artist "John Buchan" \
  --meta-disc-total 2 \
  --meta-cover-file ./cover.jpg \
  *.mp3 --dry-run
  
tone tag --meta-disc-number 1 De\ 39\ trinn\ -\ Cd\ 01\ Track*.mp3 --dry-run
tone tag --meta-disc-number 2 De\ 39\ trinn\ -\ Cd\ 02\ Track*.mp3 --dry-run
