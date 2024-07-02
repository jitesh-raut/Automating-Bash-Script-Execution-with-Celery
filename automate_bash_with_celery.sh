#!/bin/bash

# Step 1: Create a Bash Script
echo 'Creating Bash script...'
cat << 'EOF' > hello_world.sh
#!/bin/bash
echo "Hello, World!"
EOF
chmod +x hello_world.sh
echo 'Bash script created: hello_world.sh'

# Step 2: Install Redis and Celery
echo 'Installing Redis and Celery...'
sudo apt update
sudo apt install -y redis-server
pip install celery redis
echo 'Redis and Celery installed successfully'

# Step 3: Create Celery Task
echo 'Creating Celery task...'
cat << 'EOF' > celery_task.py
from celery import Celery
import subprocess

app = Celery('celery_task', broker='redis://localhost:6379/0', backend='redis://localhost:6379/0')

@app.task
def run_bash_script(script_path):
    result = subprocess.run([script_path], capture_output=True, text=True)
    return result.stdout
EOF
echo 'Celery task created: celery_task.py'

# Step 4: Create Celery Configuration
echo 'Creating Celery configuration...'
cat << 'EOF' > celery_config.py
from celery.schedules import crontab
from celery_task import app

app.conf.beat_schedule = {
    'run-hello-world-script': {
        'task': 'celery_task.run_bash_script',
        'schedule': crontab(minute='*/1'),  # runs every minute
        'args': ('hello_world.sh',)
    }
}

app.conf.timezone = 'UTC'
EOF
echo 'Celery configuration created: celery_config.py'

# Step 5: Starting Celery Worker and Beat Scheduler
echo 'Starting Celery worker and beat scheduler...'
gnome-terminal -- bash -c "celery -A celery_task worker --loglevel=info"
gnome-terminal -- bash -c "celery -A celery_task beat --loglevel=info"
echo 'Celery worker and beat scheduler started'

echo 'Configuration completed successfully.'
echo 'The Celery task is set to run the Bash script "hello_world.sh" every minute.'
