1. Setup MongoDB
	1.1. mongo$ use foo
	1.2. db.testing.insert({"a":1})
	1.3. show collections % Shows testing.
2. Run python pymongo2.py
3. Run pymongo3.py 
4. Finish threshold: support and confidence functions done; TODO: find all pairs that respect thresholds. :::NOTE::: pairs are counted twice, meaning that both (bread, soda) and (soda, bread) exist.