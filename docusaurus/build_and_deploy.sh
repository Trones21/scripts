#!/bin/bash
bash ./update_progress_md.sh

npx docusaurus build

bash ./DEPLOY_ONLY.sh