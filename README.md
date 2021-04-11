# jupyter-pi
JupyterLab Server on Raspberry Pi (Arm64). 
Read more about [Jupyterlab](https://github.com/jupyterlab/jupyterlab)

Your own Jupyter Notebook Server on [Raspberry Pi](https://www.raspberrypi.org).

----------
This is a Dockerfile for building __jupyter-pi__. The image is built on [Ubuntu 18.04](http://blog.hypriot.com/). It is a minimal notebook server with jupyter, jupyterlab and node.js (for installing additional extensions for jupyter server).  


### Installing
    docker pull johnmakridis/jupyter-pi


### Running in detached mode
    docker run -d --name jupyter -p 8080:8888 -v jupyter_data:/root johnmakridis/jupyter-pi:latest 

Now you can access your notebook at `http://<docker host IP address>:8080`

### Configuration
If you would like to change some config, you can edit the file on **/root/.jupyter/jupyter_notebook_config.py** on the docker container and then restart it.

View more about jupyter configuration [here](https://jupyter-notebook.readthedocs.io/en/stable/config.html).



The following command gives you a bash session in the running container so you could do more:

    docker exec -it <container id> /bin/bash
