This is an example rst document. Use this document to ensure that rst is being
correctly rendered.

.. code:: python

   import pytest

   @pytest.fixture
   def app(sessionmaker: sessionmaker_):
       this should be an error
       
       ...
