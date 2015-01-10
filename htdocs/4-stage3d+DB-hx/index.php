<?php
$file = 'score.txt';

// запишем данные таблицы рекордов, если они переданы
if(isset($_POST["highscores"])) {
	file_put_contents($file, $_POST["highscores"]);
}

// выведем файл или ноль если он не создан
if (file_exists($file)) {
	echo file_get_contents($file);
	exit;
} else {
	echo "0";
	exit;
}