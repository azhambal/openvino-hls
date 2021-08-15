from flask import Flask, render_template, send_from_directory

app = Flask(__name__)


@app.route("/")
def hello():
    return render_template("index.html")

@app.route('/video/<string:file_name>')
def stream(file_name):
    video_dir = './video'
    return send_from_directory(directory=video_dir, filename=file_name)

if __name__ == "__main__":
    # Only for debugging while developing
    app.run(host="0.0.0.0", debug=True, port=80)
