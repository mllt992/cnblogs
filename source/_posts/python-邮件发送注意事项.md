---
title: '[python]邮件发送注意事项'
date: 2024-07-06 07:36:35
tags:[python]
---



##  邮件格式

关于发信，需要遵循国际发信协议要求[4]，例如RFC5322协议，避免因为格式不合法，导致被收信服务器拒收。

在二零二三年以前，在开发Python的邮箱发信接口时，对邮箱格式要求不高，主要还算因为发信协议的不够完善，因此之前发信接口的开发比较随意，但随着近年来的发展，电子邮件的广泛应用，邮件相关协议也逐渐完善，例如在RFC2047, RFC822协议，明确支出了邮件标头"From"的形式有两种写法，第一种写法是邮箱地址的形式（用户名@邮件服务器域名），第二种写法是“昵称”+空格+<“邮件地址”> 的形式，并且规定如果昵称不仅仅包含ASCLL字符时，需要使用base64对昵称进行编码，并且规定昵称使用base64编码后的最终格式为"=?" charset "?" encoding "?" encoded-text "?="



## 相关文献

①https://www.rfc-editor.org/rfc/rfc5322 

②https://www.rfc-editor.org/rfc/rfc822 ③https://www.rfc-editor.org/rfc/rfc2047





## 参考代码



```python
# -*- coding: UTF-8 -*-
# 开发人员：萌狼蓝天
# 博客：Https://mllt.cc
# 笔记：Https://cnblogs.com/mllt
# 哔哩哔哩/微信公众号：萌狼蓝天
# 开发时间：2022/5/6
# Coding：UTF-8
import hashlib

import flask, json
from flask import request
import smtplib
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.header import Header
import random


class EmailSentObject:
    """
    发送邮件对象
    """
    mail_host = "smtp.ym.163.com"  # 网易企业邮箱SMTP服务器
    mail_admin = '请输入邮箱'  # 企业邮箱账号
    mail_pwd = '请输入密码'  # 企业邮箱密码
    mail_sender = "请输入邮箱"  # 企业邮箱账号
    admin_name = "萌狼工作室"  # 发信人姓名
    admin_name_base64 = '=?utf-8?B?6JCM54u85bel5L2c5a6k?='
    admin_email = mail_sender  # 发信人邮箱 与企业邮箱账号保持一致

    # nc -w 2 smtp.ym.163.com 465 < /dev/null && echo "port is ok"
    def __init__(self, receiver_email, receivers_name, subject, content):
        """
        邮件发送对象参数
        :param receiver_email: 接收者邮件，类型为List
        :param receivers_name: 接收者姓名，类型为string
        :param subject: 邮件主题，类型为string
        :param content: 邮件正文，支持解析HTML标签，类型为string
        """
        self.receivers_email = receiver_email  # 接收者邮件，类型为List
        self.receivers_name = receivers_name  # 接收者姓名，类型为string
        self.subject = subject  # 邮件主题，类型为string
        self.content = content  # 邮件正文，支持解析HTML标签，类型为string

    def sent(self):
        """
        发送邮件
        :return: 成功返回 True | 失败返回 False
        """
        message = MIMEMultipart('related')
        message['From'] = '"{}" <{}>'.format(self.admin_name_base64, self.admin_email)
        # message['From'] = Header('{}'.format(self.admin_email), 'utf-8')  # 发信人
        # message['From'] = Header('"{}" <{}>'.format(self.admin_name_base64, self.admin_email), 'utf-8', header_name="From")  # 发信人
        print(message['From'])
        message['To'] = Header(self.receivers_email, 'utf-8')  # 收信人
        message['Subject'] = Header(self.subject, 'utf-8')  # 邮件主题
        msgAlternative = MIMEMultipart('alternative')
        message.attach(msgAlternative)
        msgAlternative.attach(MIMEText(self.content, 'html', 'utf-8'))
        try:
            smtpObj = smtplib.SMTP_SSL(self.mail_host)  # 连接发信服务器
            smtpObj.connect(self.mail_host, 465)
            smtpObj.login(self.mail_admin, self.mail_pwd)  # 发信账号连接
            smtpObj.sendmail(self.mail_sender, self.receivers_email, message.as_string())  # 发送邮件
            return True
        except  smtplib.SMTPException:
            return False


def send_email_code(receiver, name):
    code = str(random.randint(0, 10)) + str(random.randint(0, 9)) + str(random.randint(0, 9)) + str(
        random.randint(0, 9)) + str(random.randint(0, 9)) + str(random.randint(0, 9))
    subject = "【验证码】萌狼工作室旗下产品用户操作验证码"
    content = """
    <p>[萌狼工作室]操作验证，您的验证码为</p>
    <h1>{}<h1>
    <p>请勿泄露自己的验证码。</p>
    <p>如果这不是你自己操作获得的邮件，忽略即可。</p>
    <small>（本邮件发送发送自萌狼工作室通知专用企业邮箱，无需回复）</small>
    """.format(code)
    sent = EmailSentObject(receiver, name, subject, content).sent()
    if sent:
        return code
    else:
        return -1


def send(receiver, name, key):
    if receiver == "":
        return {"Error": 0, "提示": "未填写收信邮箱"}  # 未填写邮箱
    if name == "":
        name = receiver
    md5hash = hashlib.md5()
    md5hash.update(key.encode(encoding='utf-8'))
    md5 = md5hash.hexdigest()
    if md5 == "4fa638bf5ac1d9cb8d43474a4a19294c":
        code = send_email_code(receiver, name)
        if code == -1:
            # 邮件发送失败
            return {"code":46501, "msg": "发送失败,请检查邮箱是否正确"}  # 邮件发送失败
        return {"code":1, "msg": "发送成功", "data": {"user": name, "receiver": receiver, "code": code}}
    return {"code": 46500, "msg": "没有权限"}  # 无权限操作


if __name__ == '__main__':
    key= "哔哩哔哩：萌狼蓝天"
    md5hash = hashlib.md5()
    md5hash.update(key.encode(encoding='utf-8'))
    md5 = md5hash.hexdigest()
    print(md5)

```

