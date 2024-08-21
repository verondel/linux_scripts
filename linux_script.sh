#!/bin/bash
# Выбор программы
p0() {
  clear
  echo "1 - доступность сайта; 2 - настройка VPN; 3 - облачное хранение: "
  read -p "" q

  case $q in
    1) p1 ;;
    2) p2 ;;
    3) p3 ;;
    *) p4 ;;
  esac
}

p4() {
  echo "Вы ввели некорректный номер, хотите повторить? (y/n) "
  read q
  if [ "$q" == "y" ]; then
    p0
  else
    p6
  fi
}

# Доступность сайта
p1() {
  echo "Введите URL для проверки: "
  read url
  echo "Введите продолжительность проверки в секундах: "
  read minutes
  echo "Введите периодичность проверки в секундах: "
  read interval

  # Расчет общего количества проверок
  checks=$((minutes / interval))
  resultFile="results.txt"
  [ -f "$resultFile" ] && rm "$resultFile"

  count_200=0
  count_others=0

  for ((i=1; i<=checks; i++)); do
    timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    httpCode=$(curl -s -o /dev/null -w "%{http_code}" $url)
    echo "$timestamp $httpCode" >> $resultFile

    if [ "$httpCode" = "000" ]; then
        echo "-"
    else
        echo "$httpCode"
    fi

        
    if [ "$httpCode" == "200" ]; then
      ((count_200++))
    else
      ((count_others++))
    fi
    
    sleep $interval
  done

  echo "Результаты проверки:"
  percent_200=$((count_200 * 100 / checks))
  percent_others=$((count_others * 100 / checks))
  echo "200 - $percent_200%"
  echo "Others - $percent_others%"

  p5
}

# Настройка VPN
p2() {
  # Запрос ввода данных пользователя
  echo "Введите имя пользователя: "
  read UserName
  echo "Введите пароль: "
  read -s Password  # '-s' предотвращает отображение вводимого пароля
  echo "Скачать OpenVPN? (Y): "
  read Download
  ConnectScript="/home/a1/Рабочий стол/temp/ConnectVPN.sh"
  DisconnectScript="/home/a1/Рабочий стол/temp/DisconnectVPN.sh"
  ConnectDesktop="/home/a1/Рабочий стол/temp/ConnectVPN.desktop"
  DisconnectDesktop="/home/a1/Рабочий стол/temp/DisconnectVPN.desktop"

  # Проверка необходимости установки OpenVPN
  if [ "$Download" == "Y" ]; then
      echo "Установка OpenVPN..."
      sudo apt install -y openvpn # sudo apt update &&
  fi

  AuthFilePath="/home/a1/auth.txt"
  echo "$UserName" > "$AuthFilePath"
  echo "$Password" >> "$AuthFilePath"
  echo "Файл с учетными данными создан в $AuthFilePath"

  # Скрипт подключения
  {
  echo "#!/bin/bash"
  echo "sudo openvpn --config \"/home/a1/profile-1970934955222476292.ovpn\" --log \"/home/a1/vpnlog.txt\" "
  } > "$ConnectScript"

  # Скрипт отключения
  {
  echo "#!/bin/bash"
  echo "# Находим процессы OpenVPN, использующие данный конфигурационный файл"
  echo "VPN_CONFIG=\"/home/a1/profile-1970934955222476292.ovpn\""
  echo ""
  echo "while true; do"
  echo "    VPN_PIDS=\$(pgrep -f \"openvpn --config \$VPN_CONFIG\")"
  echo "    if [ -z \"\$VPN_PIDS\" ]; then"
  echo "        echo \"Процессы VPN не найдены\""
  echo "        break"
  echo "    else"
  echo "        for PID in \$VPN_PIDS; do"
  echo "            echo \"Останавливаем VPN с PID \$PID...\""
  echo "            sudo kill \"\$PID\""
  echo "        done"
  echo "        echo \"Все найденные VPN процессы были остановлены\""
  echo "    fi"
  echo "    sleep 5"
  echo "done"
  } > "$DisconnectScript"

  chmod +x "$ConnectScript"
  chmod +x "$DisconnectScript"
  chown -c a1 "$ConnectScript"
  chown -c a1 "$DisconnectScript"
  echo "Скрипт подключения к VPN создан: $ConnectScript"
  echo "Скрипт отключения от VPN создан: $DisconnectScript"

  mkdir -p /home/a1/icons/

  echo "Файлы успешно скачаны в /home/a1/icons в папки 1 и 2"

  IconPathWork="/home/a1/icons/vpn_icon_1.png"
  IconPathChill="/home/a1/icons/vpn_icon_2.png"

  chown -c a1 $IconPathWork 
  chown -c a1 $IconPathChill 
  chmod 777 $IconPathWork 
  chnid 777 $IconPathChill 
  
  # Создание .desktop файла для подключения
  {
  echo "[Desktop Entry]"
  echo "Version=1.0"
  echo "Type=Application"
  echo "Name=Connect VPN"
  echo "Exec=bash '$ConnectScript'"
  echo "Icon='$IconPathWork'"
  echo "Terminal=false"
  } > "$ConnectDesktop"

  # Создание .desktop файла для отключения
  {
  echo "[Desktop Entry]"
  echo "Version=1.0"
  echo "Type=Application"
  echo "Name=Disconnect VPN"
  echo "Exec=bash '$DisconnectScript'"
  echo "Icon='$IconPathChill'"
  echo "Terminal=false"
  } > "$DisconnectDesktop"

  # права на выполнение для .desktop файлов
  chmod +x "$ConnectDesktop"
  chmod +x "$DisconnectDesktop"
  chown -c a1 "$ConnectDesktop"
  chown -c a1 "$DisconnectDesktop"
  chmod 755 "$ConnectDesktop"
  chmod 755 "$DisconnectDesktop"

  echo "Скрипт подключения к VPN и соответствующий .desktop файл созданы на рабочем столе."
  echo "Скрипт отключения от VPN и соответствующий .desktop файл созданы на рабочем столе."

  bash "/home/a1/Рабочий стол/temp/ConnectVPN.desktop"

  p5
}

# Облачное хранение
p3() {
  while true; do
      clear
      echo "Список доступных команд:"
      echo "1. Создать новый S3 bucket"
      echo "2. Отправить файл в S3 bucket"
      echo "3. Откатить файл к предыдущей версии"
      echo "4. Показать все версии файла в S3 bucket"
      echo "5. Выход из программы"
      echo
      read -p "Введите команду: " command

      case $command in
          1) # Создать новый S3 bucket
              echo "Введите имя будущего S3 bucket: "
              read BucketName
              aws s3api create-bucket --bucket $BucketName --endpoint-url https://s3.ru-1.storage.selcloud.ru
              aws s3api put-bucket-versioning --bucket $BucketName --versioning-configuration Status=Enabled --endpoint-url https://s3.ru-1.storage.selcloud.ru
              echo "$BucketName"
              read -p "......"
              ;;
          2) # Отправить файл в S3 bucket
              echo "Введите путь к файлу: "
              read FilePath
              if [ ! -f "$FilePath" ]; then
                  echo "Файл не существует."
                  sleep 5
              else
                  # размер локального файла
                  SizeLocal=$(stat --format="%s" "$FilePath") 

                  # имя ведра от пользователя
                  echo "Введите имя ведра: "
                  read BucketName
                  
                  # имя файла из пути
                  FileName=$(basename "$FilePath")
                  
                  aws s3api list-object-versions --bucket $BucketName --prefix "$FileName" --endpoint-url https://s3.ru-1.storage.selcloud.ru > temp_versions.txt

                  # поиск первого значения размера файла в ведре
                  SizeInBucket=$(grep '"Size":' temp_versions.txt | awk '{print $2}' | tr -d ',' | head -n 1)
                  echo "Локальный размер: $SizeLocal"
                  echo "Размер в ведре: $SizeInBucket"

                  if [ "$SizeInBucket" != "$SizeLocal" ]; then
                      # Размеры файлов различаются, отправка файла
                      aws s3 cp "$FilePath" s3://$BucketName/$FileName --endpoint-url https://s3.ru-1.storage.selcloud.ru
                      echo "Файл успешно отправлен."
                      read -p "......"
                  else
                      # Размеры файлов совпадают, запрос на засорение
                      read -p "Уже существует такой объект с таким же размером. Вы уверены, что хотите засорить ведро компании еще больше? (Y/N): " UserInput
                      if [ "$UserInput" == "Y" ] || [ "$UserInput" == "y" ]; then
                          aws s3 cp "$FilePath" s3://$BucketName/$FileName --endpoint-url https://s3.ru-1.storage.selcloud.ru
                          echo "Поздравляем с успешным засорением!"
                          read -p "......"
                      else
                          echo "Спасибо, что цените деньги компании!"
                          read -p "......"
                      fi
                  fi
              fi
              rm temp_versions.txt
              ;;
          3) # Откатить файл к предыдущей версии
              echo "Введите имя файла для отката: "
              read FileName
              echo "Введите имя ведра: "
              read BucketName
              aws s3api list-object-versions --bucket $BucketName --prefix "$FileName" --endpoint-url https://s3.ru-1.storage.selcloud.ru > temp_versions.txt
              echo "Возможные версии файла $FileName:"

              # Подсчет количества версий
              totalCount=$(jq '.Versions | length' temp_versions.txt)
              echo Всего версий: $totalCount

              # Инициализация счетчика
              counter=$(($totalCount - 1))

              # Обработка каждой версии
              jq -r '.Versions[] | "\(.LastModified) \(.VersionId)"' temp_versions.txt | while read line; do
                  echo "$counter $line"
                  let counter--
              done > output.txt
              cat output.txt

              # Чтение номера версии от пользователя для отката
              while true; do
                  echo "Введите номер версии для отката от 0 до $(($totalCount - 2)): "
                  read versionNumber
                  if [[ ! $versionNumber =~ ^[0-9]+$ ]] || [ "$versionNumber" -lt 0 ] || [ "$versionNumber" -gt "$(($totalCount - 2))" ]; then
                      echo "Некорректный номер версии. Пожалуйста, попробуйте еще раз."
                  else
                      break
                  fi
              done

              # Вычисление номера строки для извлечения VersionId
              lineNumber=$(($totalCount - $versionNumber))
              versionId=$(awk "NR==$(($lineNumber)) {print \$3}" output.txt)

              aws s3api copy-object --endpoint-url https://s3.ru-1.storage.selcloud.ru --bucket $BucketName --copy-source $BucketName/"$FileName"?versionId="$versionId" --key "$FileName" 
              rm output.txt
              rm temp_versions.txt
              echo Откат выполнен к версии  $versionId.
              read -p "......"
              ;;
          4) # Показать все версии файла в S3 bucket
              echo "Введите имя файла: "
              read FileName
              echo "Введите имя ведра: "
              read BucketName
              aws s3api list-object-versions --bucket $BucketName --prefix "$FileName" --endpoint-url https://s3.ru-1.storage.selcloud.ru
              read -p "......"
              ;;
          5) # Выход из программы
              break
              ;;
          *)
              echo "Неверная команда."
              read -p "......"
              ;;
      esac
  done
  p5
}

# Повтор операции
p5() {
  echo "Вы хотите выбрать другую операцию? (y/n) "
  read q
  if [ "$q" == "y" ]; then
    p0
  else
    p6
  fi
}

# Завершение скрипта
p6() {
  echo "До связи"
}

p0
