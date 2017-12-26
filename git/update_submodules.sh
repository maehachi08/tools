#!/bin/bash

git submodule status | awk '{print $2}' | xargs -P8 -n1 git submodule update --init
git submodule foreach git pull origin master

for submodule in $(git status -s | awk '{print $2}'); do
  summary=$(git submodule summary ${submodule})
  git add ${submodule}
  git commit -F- <<EOM
	update ${submodule} submodule
	
	---
	
	${summary}
EOM
done
