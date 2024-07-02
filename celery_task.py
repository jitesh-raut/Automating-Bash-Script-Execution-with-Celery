from celery import Celery
import subprocess

app = Celery('celery_task', broker='redis://localhost:6379/0', backend='redis://localhost:6379/0')

@app.task
def run_bash_script(script_path):
    result = subprocess.run([script_path], capture_output=True, text=True)
    return result.stdout
