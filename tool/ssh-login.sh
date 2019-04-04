echo '都使用默认就行--------------'
ssh-keygen -t rsa

echo '拷贝 id_rsa.pub 的内容追加至要登录的服务器的~/.ssh/authorized_keys文件中';
read -p "请输入要登录的服务器的ip: " remote_ip
[ -z "$remote_ip" ] && remote_ip="no"
read -p "请输入要登录的服务器的port: " remote_port
[ -z "$remote_port" ] && remote_port="22"
if [ "$remote_ip" != "no" ]; then
	ssh-copy-id -i ~/.ssh/id_rsa.pub root@$remote_ip -p $remote_port
else
	echo '服务器ip不能为空'
fi

# 假定 机器A 连接至 机器B 。

# 1. 在机器A上，生成RSA秘钥对

# ssh-keygen -t rsa
# 期间passphrase不输入密码。默认生成文件至 ~/.ssh/

# -rw------- 1 webadmin webadmin 1675 10月 17 12:09 id_rsa
# -rw-r--r-- 1 webadmin webadmin  405 10月 17 12:09 id_rsa.pub


# 2. 拷贝 id_rsa.pub 的内容追加至机器B的~/.ssh/authorized_keys文件中。可以手动拷贝，也可以如下远程操作：

# ssh-copy-id -i ~/.ssh/id_rsa.pub test1@10.10.10.123

# 3. 检查机器B上的/etc/ssh/sshd_config，需确保下列配置有效：

# RSAAuthentication yes
# PubkeyAuthentication yes
# AuthorizedKeysFile      .ssh/authorized_keys


# 4. 检查机器B上的 ~/.ssh/authorized_keys的权限，必须为600。其实是必须group和others的权限为0。如果不是，则执行

# chmod 600 ~/.ssh/authorized_keys


# 5. 如果修改过sshd_config，则重启服务：

# service sshd restart


# 6. 测试自动登录ssh

# ssh test1@10.10.10.123