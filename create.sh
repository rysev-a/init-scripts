#create new project

echo "Имя нового проекта"
read project
echo "Администратор проекта"
read user
echo "Пароль базы данных"
read dbpass
echo "Порт gunicorn"
read port

sudo -u postgres createdb $project

echo "
server {
    listen 80;
    server_name $project;
    root /home/$user/www/$project/static/public;
    access_log /home/$user/www/$project/logs/access.log;
    error_log /home/$user/www/$project/logs/error.log;
    location / {
        proxy_set_header X-Forward-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
        if (!-f \$request_filename) {
            proxy_pass http://127.0.0.1:$port;
            break;
        }
    }
}
" >> /etc/nginx/sites-available/$project
ln -s /etc/nginx/sites-available/$project /etc/nginx/sites-enabled/$project

echo "
command = /home/$user/www/$project/env/bin/gunicorn app:app -b localhost:$port --reload
directory = /home/$user/www/$project
autostart=true
autorestart=true
startsecs=10
startretries=3
exitcodes=0,2
stopsignal=TERM
stopwaitsecs=10
user = $user
" >> /etc/supervisor/conf.d/$project.conf

cd /home/$user/www
git clone https://github.com/rysev-a/flask-start.git $project
cd $project
virtualenv env
source env/bin/activate
pip install -r requirements.txt

sed -i "s/dbname/$project/g" /home/$user/www/$project/application/database.py
sed -i "s/dbuser/$user/g" /home/$user/www/$project/application/database.py
sed -i "s/dbpass/$dbpass/g" /home/$user/www/$project/application/database.py