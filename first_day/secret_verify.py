# encoding: utf-8
# @File   : calculate_hash_time.py
# @Author : Derrick
# @Desc   :
# @Date   : 4/28/25 16:23


import hashlib
import time
import uuid
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.exceptions import InvalidSignature

def find_valid_hash(nickname, leading_zeros):
    """
    寻找满足指定前导零数量的哈希值，使用 UUID 作为 nonce

    :param nickname: 昵称
    :param leading_zeros: 前导零的数量
    :return: nonce、哈希值、耗时
    """
    start_time = time.time()
    target = "0" * leading_zeros

    while True:
        nonce = str(uuid.uuid4())
        data = f"{nickname}{nonce}".encode('utf-8')
        hash_hex = hashlib.sha256(data).hexdigest()
        if hash_hex.startswith(target):
            end_time = time.time()
            elapsed_time = end_time - start_time
            return nonce, hash_hex, elapsed_time

def generate_rsa_keys():
    """
    生成 RSA 公私钥对

    :return: 私钥和公钥
    """
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
    )
    public_key = private_key.public_key()
    return private_key, public_key

def sign_data(private_key, data):
    """
    使用私钥对数据进行签名

    :param private_key: 私钥
    :param data: 待签名的数据
    :return: 签名
    """
    signature = private_key.sign(
        data,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )
    return signature

def verify_signature(public_key, data, signature):
    """
    使用公钥验证签名

    :param public_key: 公钥
    :param data: 原始数据
    :param signature: 签名
    :return: 验证结果，True 表示验证通过，False 表示验证失败
    """
    try:
        public_key.verify(
            signature,
            data,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        return True
    except InvalidSignature:
        return False

if __name__ == "__main__":
    nickname = "Derrick"  # 替换为你的昵称

    # 计算 4 个 0 开头的哈希
    nonce_4, hash_4, time_4 = find_valid_hash(nickname, 4)
    print(f"4 个 0 开头:")
    print(f"Nonce: {nonce_4}")
    print(f"哈希值: {hash_4}")
    print(f"耗时: {time_4:.4f} 秒")
    print()

    # 计算 5 个 0 开头的哈希
    nonce_5, hash_5, time_5 = find_valid_hash(nickname, 5)
    print(f"5 个 0 开头:")
    print(f"Nonce: {nonce_5}")
    print(f"哈希值: {hash_5}")
    print(f"耗时: {time_5:.4f} 秒")

    # 生成 RSA 公私钥对
    private_key, public_key = generate_rsa_keys()

    # 选择 4 个 0 开头的结果进行签名
    data_to_sign = f"{nickname}{nonce_4}".encode('utf-8')

    # 用私钥签名
    signature = sign_data(private_key, data_to_sign)

    # 用公钥验证签名
    is_valid = verify_signature(public_key, data_to_sign, signature)

    print("\nRSA 签名验证结果:")
    print(f"签名验证是否通过: {is_valid}")