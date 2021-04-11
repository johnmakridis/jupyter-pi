FROM ubuntu:18.04
MAINTAINER John Makridis <jmakridis7@gmail.com>

# Define timezone
ENV TZ=Europe/Athens
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


WORKDIR /root


# Install required packages
RUN apt-get update
RUN apt-get install -y build-essential python3.6 python3-pip python3-dev 
RUN apt-get install -y libncurses5-dev libncursesw5-dev idle3
RUN apt-get install -y curl nano

# Install nodejs (for installing jupyter extensions)
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash
RUN apt-get install -y nodejs


# Update pip
RUN pip3 -q install pip --upgrade


# Install jupyter
RUN pip3 install gnureadline ipywidgets jupyter jupyterlab

# Configure jupyter
RUN jupyter nbextension enable --py widgetsnbextension
RUN jupyter serverextension enable --py jupyterlab
RUN jupyter notebook --generate-config

RUN mkdir notebooks

RUN sed -i "/c.NotebookApp.open_browser/c c.NotebookApp.open_browser = False" /root/.jupyter/jupyter_notebook_config.py \
        && sed -i "/c.NotebookApp.ip/c c.NotebookApp.ip = '*'" /root/.jupyter/jupyter_notebook_config.py \
        && sed -i "/c.NotebookApp.notebook_dir/c c.NotebookApp.notebook_dir = '/root/notebooks'" /root/.jupyter/jupyter_notebook_config.py \
        && sed -i "/c.NotebookApp.allow_credentials/c c.NotebookApp.allow_credentials = True" /root/.jupyter/jupyter_notebook_config.py \
        && sed -i "/c.NotebookApp.allow_origin/c c.NotebookApp.allow_origin = '*'" /root/.jupyter/jupyter_notebook_config.py \
        && sed -i "/c.NotebookApp.allow_remote_access/c c.NotebookApp.allow_remote_access = True" /root/.jupyter/jupyter_notebook_config.py \
        && sed -i "/c.NotebookApp.allow_root/c c.NotebookApp.allow_root = True" /root/.jupyter/jupyter_notebook_config.py \
        && sed -i "/c.NotebookApp.default_url/c c.NotebookApp.default_url = '/tree'" /root/.jupyter/jupyter_notebook_config.py \
        && sed -i "/c.NotebookApp.port/c c.NotebookApp.port = 8888" /root/.jupyter/jupyter_notebook_config.py \
        && sed -i "/c.NotebookApp.quit_button/c c.NotebookApp.quit_button = False" /root/.jupyter/jupyter_notebook_config.py \
        && sed -i "/c.KernelManager.autorestart/c c.KernelManager.autorestart = True" /root/.jupyter/jupyter_notebook_config.py \
        && sed -i "/c.MultiKernelManager.default_kernel_name/c c.MultiKernelManager.default_kernel_name = 'python3'" /root/.jupyter/jupyter_notebook_config.py


VOLUME /root


# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION 0.18.0
ENV CFLAGS="-DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37"

ADD https://github.com/krallin/tini/archive/v${TINI_VERSION}.tar.gz /root/v${TINI_VERSION}.tar.gz
RUN apt-get install -y cmake
RUN tar zxvf v${TINI_VERSION}.tar.gz \
        && cd tini-${TINI_VERSION} \
        && cmake . \
        && make \
        && cp tini /usr/bin/. \
        && cd .. \
        && rm -rf "./tini-${TINI_VERSION}" \
        && rm "./v${TINI_VERSION}.tar.gz"

ENTRYPOINT ["/usr/bin/tini", "--"]


EXPOSE 8888


CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]


