# encoding: utf-8
# @File   : calculate_hash_time.py
# @Author : Derrick
# @Desc   :
# @Date   : 4/28/25 16:23

# 实践 POW 用自己的昵称 + nonce, 不断的 sha256 Hash :
# ❖ 直到满足 4个0开头,打印出花费的时间
# ❖ 直到满足 5个0开头,打印出花费的时间

import hashlib
import time
import uuid

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
