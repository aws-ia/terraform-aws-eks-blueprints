name: tfsec

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]  

jobs:
  tfsec:
    name: Run tfsec sarif report
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    steps:
      - name: Clone repo
        uses: actions/checkout@master
        
      - name: Run tfsec
        uses: tfsec/tfsec-sarif-action@master
        with:
          sarif_file: tfsec.sarif         

      - name: Upload SARIF file
        uses: github/codeql-action/upload-sarif@v1
        with:
          sarif_file: tfsec.sarif  
