from flask import Flask, render_template_string
import subprocess

app = Flask(__name__)
stress_processes = []

HTML = """
<h1>Hybrid Auto Scaling Control Panel</h1>

<form action="/increase"><button>Increase Load (+1)</button></form>
<form action="/decrease"><button>Decrease Load (-1)</button></form>
<form action="/stop"><button>Stop All Load</button></form>
<form action="/logs"><button>View Logs</button></form>

<p>Current Load Level: {{load}}</p>
"""

@app.route("/")
def home():
    return render_template_string(HTML, load=len(stress_processes))

@app.route("/increase")
def increase():
    p = subprocess.Popen(["stress", "--cpu", "1"])
    stress_processes.append(p)
    return f"Load Increased → {len(stress_processes)} <br><a href='/'>Back</a>"

@app.route("/decrease")
def decrease():
    if stress_processes:
        p = stress_processes.pop()
        p.terminate()
    return f"Load Level → {len(stress_processes)} <br><a href='/'>Back</a>"

@app.route("/stop")
def stop():
    global stress_processes
    for p in stress_processes:
        p.terminate()
    stress_processes = []
    return "All Load Stopped <br><a href='/'>Back</a>"

@app.route("/logs")
def logs():
    try:
        with open("scaling.log") as f:
            content = f.read()
    except:
        content = "No logs yet"
    return f"<pre>{content}</pre><br><a href='/'>Back</a>"

app.run(host="0.0.0.0", port=5000)


