#!/bin/bash
if [ ! -d "UxFooocus" ]
then
  git clone https://github.com/rafiislambd/UxFooocus.git
  #git clone --depth 1 --branch V2 https://github.com/lllyasviel/Fooocus.git
  # Create the config file pointing the checkpoints to checkpoints-real-folder
fi
cd UxFooocus
git pull
if [ ! -L ~/.conda/envs/UxFooocus ]
then
    ln -s /tmp/UxFooocus ~/.conda/envs/
fi
eval "$(conda shell.bash hook)"
if [ ! -d /tmp/UxFooocus ]
then
    mkdir /tmp/UxFooocus
    conda env create -f environment.yaml
    conda activate UxFooocus
    pwd
    ls
    pip install -r requirements_versions.txt
    pip install torch torchvision --force-reinstall --index-url https://download.pytorch.org/whl/cu117
    pip install pyngrok
    conda install glib -y
    rm -rf ~/.cache/pip
fi

# Because the file manager in Sagemaker Studio Lab ignores the folder called "checkpoints"
# we need to move checkpoint files into a folder with a different name
current_folder=$(pwd)
model_folder=${current_folder}/models/checkpoints-real-folder
if [ ! -e config.txt ]
then
  json_data="{ \"path_checkpoints\": \"$model_folder\" }"
  echo "$json_data" > config.txt
  echo "JSON file created: config.txt"
else
  echo "Updating config.txt to use checkpoints-real-folder"
  jq --arg new_value "$model_folder" '.path_checkpoints = $new_value' config.txt > config_tmp.txt && mv config_tmp.txt config.txt
fi

# If the checkpoints folder exists, move it to the new checkpoints-real-folder
if [ ! -L models/checkpoints ]
then
    mv models/checkpoints models/checkpoints-real-folder
    ln -s models/checkpoints-real-folder models/checkpoints
fi

conda activate UxFooocus
cd ..
if [ $# -eq 0 ]
then
  python start-ngrok.py 
elif [ $1 = "reset" ]
then
  python start-ngrok.py --reset 
fi
