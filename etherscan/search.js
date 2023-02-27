<!DOCTYPE html>
<html>
<head>
	<title>Search Bar Example</title>
	<style type="text/css">
		#search-box {
			padding: 10px;
			border: 1px solid #ccc;
			border-radius: 5px;
			width: 300px;
			margin: 10px;
			font-size: 16px;
		}
		#search-results {
			padding: 10px;
			border: 1px solid #ccc;
			border-radius: 5px;
			width: 300px;
			margin: 10px;
			display: none;
		}
		.search-result {
			padding: 5px;
			cursor: pointer;
		}
		.search-result:hover {
			background-color: #f4f4f4;
		}
	</style>
</head>
<body>
	<input type="text" id="search-box" placeholder="Search...">
	<div id="search-results"></div>
	<script type="text/javascript">
		// 검색창 요소 가져오기
		const searchBox = document.getElementById('search-box');
		// 검색 결과를 표시할 요소 가져오기
		const searchResults = document.getElementById('search-results');

		// 검색창에서 입력할 때마다 호출되는 함수
		searchBox.addEventListener('input', function() {
			// 검색어 가져오기
			const query = searchBox.value.trim().toLowerCase();
			// 검색어가 없으면 검색 결과를 숨기고 함수 종료
			if (query.length === 0) {
				searchResults.style.display = 'none';
				return;
			}
			// 검색 결과를 표시하는 함수 호출
			showSearchResults(query);
		});

		// 검색 결과를 표시하는 함수
		function showSearchResults(query) {
			// TODO: 검색 결과를 가져오는 API 호출 등의 로직을 추가

			// 예제에서는 간단하게 검색어를 포함하는 문자열을 검색 결과로 표시
			const results = ['Apple', 'Banana', 'Cherry', 'Durian', 'Eggplant'];
			const filteredResults = results.filter(result => result.toLowerCase().includes(query));

			// 검색 결과가 없으면 검색 결과를 숨기고 함수 종료
			if (filteredResults.length === 0) {
				searchResults.style.display = 'none';
				return;
			}

			// 검색 결과를 HTML로 변환하여 검색 결과 요소에 삽입
			searchResults.innerHTML = '';
			filteredResults.forEach(result => {
				const resultElement = document.createElement('div');
				resultElement.classList.add('search-result');
				resultElement.textContent = result;
				resultElement.addEventListener('click', function() {
					searchBox.value = result;
					searchResults.style.display = 'none';
				});
				searchResults.appendChild(resultElement);
			});

			// 검색 결과를 표시
			searchResults.style.display = 'block';
		}
	</script>
</body>
</html>
