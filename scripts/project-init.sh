#!/usr/bin/env bash
# Initialize a new project with common files

if [ -z "$1" ]; then
    echo "Usage: project-init <project-name> [type]"
    echo "Types: node, python, go, rust"
    exit 1
fi

PROJECT_NAME=$1
PROJECT_TYPE=${2:-general}

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize git
git init

# Create common files
echo "# $PROJECT_NAME" > README.md
cp ~/.gitignore_global .gitignore
touch .env.example

# Create basic directory structure
mkdir -p src tests docs

# Type-specific initialization
case $PROJECT_TYPE in
    node)
        npm init -y
        npm install --save-dev typescript @types/node eslint prettier
        cp ~/.eslintrc.json .
        cp ~/.prettierrc .
        ;;
    python)
        python3 -m venv venv
        source venv/bin/activate
        pip install black flake8 pytest
        echo "venv/" >> .gitignore
        ;;
    go)
        go mod init "github.com/$(git config user.name)/$PROJECT_NAME"
        ;;
    rust)
        cargo init
        ;;
esac

echo "Project $PROJECT_NAME initialized!"
