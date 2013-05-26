import os

from flask import Flask, render_template, url_for, request

app = Flask(__name__)

@app.route("/")
def index():
	print url_for('static', filename='main.css')
	return render_template('index.html')

@app.route("/interpret", methods=['POST'])
def interpret():
	from plumbum import local
	from plumbum.cmd import timeout
	useless_code = request.form['code']
	res = timeout[3,local['./baudot-code/stub'][useless_code]]()
	return res


if __name__ == "__main__":
	app.debug = True
	app.run()