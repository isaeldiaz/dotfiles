import os
from flask import Flask, render_template, request

app = Flask(__name__)


@app.route('/')
def home():
    return render_template('home.html')


@app.route('/shortenurl', methods=['GET', 'POST'])
def shortenurl():
    if request.method == 'POST':
        return render_template('shortenurl.html', shortcode=request.form['shortcode'])
    elif request.method == 'GET':
        return 'A GET request was made'
    else:
        return 'Not a valid request method for this route' 
 



if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=True,host='0.0.0.0',port=port)
