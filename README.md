# Generate source file from xsl

## Steps

This folder contains xsl files which can generate source files.

The workflow is simple and can be summarized in these few steps:

1. On ubuntu 18.04, install pre-required package using:
    ```
    $ apt-get install -y xsltproc
    ```

1. Generate source file by running
    ```
    $ xsltproc vm_configuration.c.xsl hybrid_rt.xml
    ```

