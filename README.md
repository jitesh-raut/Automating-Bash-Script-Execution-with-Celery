# Automating-Bash-Script-Execution-with-Celery
This repository demonstrates how to automate the execution of a Bash script using Celery and Redis on WSL Ubuntu. for demo, For example, It includes a simple "Hello, World!" Bash script, a Celery task to run the script, and configuration for scheduling the task with Celery Beat. Perfect for learning task automation and scheduling with Celery.

---

## OS Used

Ubuntu
---

To achieve this, follow these steps:

1. Create a Bash script that prints "Hello, World!"
2. Install and configure Celery and Redis
3. Create a Celery task to run the Bash script
4. Set up Celery to run the task on a schedule

### Step 1: Create a Bash Script

First, create a Bash script that prints "Hello, World!".

1. Create a file named `hello_world.sh` with the following content:

    ```bash
    #!/bin/bash
    echo "Hello, World!"
    ```

2. Make the script executable:

    ```bash
    chmod +x hello_world.sh
    ```

### Step 2: Install and Configure Celery and Redis

You'll need to install Celery and a message broker like Redis or RabbitMQ. Here we'll use Redis.

1. Update your package list and install Redis:

    ```bash
    sudo apt update
    sudo apt install redis-server
    ```

2. Install Celery and Redis Python libraries using `pip`:

    ```bash
    pip install celery redis
    ```

3. Start the Redis server:

    ```bash
    sudo service redis-server start
    ```

### Step 3: Create a Celery Task

Create a new Python file, `celery_task.py`, and define a Celery task to run the Bash script.

1. Create a file named `celery_task.py` with the following content:

    ```python
    from celery import Celery
    import subprocess

    app = Celery('celery_task', broker='redis://localhost:6379/0', backend='redis://localhost:6379/0')

    @app.task
    def run_bash_script(script_path):
        result = subprocess.run([script_path], capture_output=True, text=True)
        return result.stdout
    ```

2. Ensure you have a `__main__.py` to allow running the Celery app:

    ```python
    if __name__ == '__main__':
        app.start()
    ```

### Step 4: Set Up Celery to Run the Task on a Schedule

Celery can be scheduled using Celery Beat. Create a new file, `celery_config.py`, and configure the periodic task.

1. Create a file named `celery_config.py` with the following content:

    ```python
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
    ```

### Running Celery

Now that the tasks and schedules are set up, you can start the Celery worker and the Celery Beat scheduler.

1. Start the Celery worker:

    ```bash
    celery -A celery_task worker --loglevel=info
    ```

2. Start the Celery Beat scheduler:

    ```bash
    celery -A celery_task beat --loglevel=info
    ```

### Customization and Scaling

You can customize and scale your Celery setup based on your needs:

- **Changing the Schedule**: Update the `crontab` schedule in `celery_config.py` to run at different intervals.

    ```python
    'schedule': crontab(minute='*/5'),  # runs every 5 minutes
    ```

- **Running Different Scripts**: Pass different Bash scripts by updating the `args` parameter.

    ```python
    'args': ('/path/to/another_script.sh',)
    ```


### Troubleshooting

- **Redis Server Issues**: Ensure the Redis server is running. Use `sudo service redis-server status` to check the status.
- **Celery Worker Issues**: Ensure the Celery worker is running. Check logs for any errors using `--loglevel=debug`.

### Additional Resources

- [Celery Documentation](https://docs.celeryproject.org/en/stable/)
- [Redis Documentation](https://redis.io/documentation)

---
