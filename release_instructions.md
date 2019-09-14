
# TODOs for a new release:

* Change version in: `setup.py` and `docs/conf.py`.
* Commit and publish release at Github.
* Configure/build rtfd.org.
* Build and push to pypi.org:
  ```
     python3 setup.py sdist bdist_wheel
     python3 -m twine upload --repository-url https://test.pypi.org/legacy/ dist/*           # test
     twine upload dist/*                                                                     # prod
  ```
