Run the following commands to download the data for tests in test_taxonomake_download.py.

- For 'test_taxonomake_gtdbtk_r207':

  ```sh
  taxonomake --download tests/data/community_gtdbtk_r207.yaml
  ```

- For 'test_taxonomake_gtdbtk_r226':

  ```sh
  taxonomake --download tests/data/community_gtdbtk_r226.yaml
  ```

Run expensive tests with profile

```sh
SNAKEMAKE_PROFILE=<profile> TEMPDIR="<tempdir>" pytest --run-expensive
```