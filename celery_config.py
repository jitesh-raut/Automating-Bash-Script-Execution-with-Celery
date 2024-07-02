from celery.schedules import crontab
from celery_task import app

app.conf.beat_schedule = {
    'run-hello-world-script': {
        'task': 'celery_task.run_bash_script',
        'schedule': crontab(minute='*/1'),  # runs every minute
        'args': ('/path/to/hello_world.sh',)
    }
}

app.conf.timezone = 'UTC'
