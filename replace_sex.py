import os
import re

def replace_text_in_files():
    # byeong_sin 폴더 경로
    folder_path = 'byeong_sin'
    
    # 폴더 내의 모든 .txt 파일 검색
    for filename in os.listdir(folder_path):
        if filename.endswith('.txt'):
            file_path = os.path.join(folder_path, filename)
            
            # 파일 읽기
            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            ## 지삐띠 섹스?
            new_content = content.replace('ChatGPT', '지피띠')
            new_content = new_content.replace('GPT', '지피띠')
            
            # 변경된 내용을 파일에 쓰기
            with open(file_path, 'w', encoding='utf-8') as file:
                file.write(new_content)
            
            print(f'{filename} 파일 처리 완료')

if __name__ == '__main__':
    replace_text_in_files() 