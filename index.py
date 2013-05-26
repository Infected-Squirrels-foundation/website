import os
import sqlite3
from flask import Flask, render_template, request
import bcpl

app = Flask(__name__)

@app.route("/", methods=['GET'])
def index():
	return render_template('index.html')

@app.route("/interpret", methods=['POST'])
def interpret():
	return bcpl.run(request.form['code'])

@app.route("/<int:code_id>", methods=['GET'])
def get_saved(code_id):
	conn = sqlite3.connect('./db')
	c = conn.cursor()
	code = c.execute('SELECT code FROM saves WHERE id=?', (code_id,)).fetchone()[0]
	conn.close()
	return render_template('index.html', code=code)

@app.route("/save", methods=['POST'])
def save():
	code = request.form['code']
	conn = sqlite3.connect('./db')
	c = conn.cursor()
	c.execute('INSERT INTO saves VALUES(NULL,?)', (code,))
	conn.commit()
	id = c.lastrowid
	conn.close()
	return str(id)

if __name__ == "__main__":
	app.debug = True
	app.run()