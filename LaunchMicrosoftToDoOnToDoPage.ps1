$command = 'shell:AppsFolder\Microsoft.Todos_8wekyb3d8bbwe!App'
$args =  'ms-to-do://accounts/1ddbb2981a014ea7a0ec7bdb82ffc986/list/LOCAL_ID_ea580d61552d4f818b9f9741b0cbfae1'
Start-process $command -ArgumentList $args