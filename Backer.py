import asyncio
import websockets
import random
import time
import shutil
async def check_permit(websocket):
    while True:
        recv_str = await websocket.recv()
        print(recv_str)
        if recv_str.split(",")[0]=='device_id':
            try:
                f = open("./user_file/"+recv_str.split(",")[1]+'.txt')
                list_words_return = []
                for line_ in f:
                    list_words_return.append(line_)
                index=random.randint(0,len(list_words_return)-1)
                # print(list_words_return)
                print(str(list_words_return[index]))
                await websocket.send(str(list_words_return[index]))
            except:
                with open("./user_file/"+recv_str.split(",")[1]+'.txt','a+')as f:
                    f.write("user_id,"+recv_str.split(",")[1]+"\n")
                await websocket.send(str("user_id,"+recv_str.split(",")[1]+" is created"))
                print("Writed at first time")
        elif recv_str.split(",")[0]=='dw':
            list_word_to_check=[]
            flag_check = 0
            f = open("./user_file/"+recv_str.split(",")[1]+'.txt')
            for line_ in f:
                print("list_word_tocheck:",line_)
                if recv_str.split(",")[2]==line_.split(",")[0]:
                    print("chongfu-------------------")
                    flag_check=1
                list_word_to_check.append(line_.split(",")[0])
            #print(list_word_to_check)
            if flag_check == 0:
                with open("./user_file/"+recv_str.split(",")[1]+'.txt','a+')as f:
                    f.write(recv_str.split(",")[2]+","+recv_str.split(",")[3]+"\n")
                    await websocket.send(str("Writed ok"))
            #print("Writed"+recv_str.split(",")[2],recv_str.split(",")[3])
            else:
                await websocket.send(str("重复"))
        elif recv_str.split(",")[0]=='get':
            f = open("./user_file/"+recv_str.split(",")[1]+'.txt')
            list_words_return = ''
            for line_ in f:
                #print(line_)
                list_words_return+=line_.strip('\n')+'-'
            print(list_words_return)
            await websocket.send(str(list_words_return))
        elif recv_str.split(",")[0]=='de':
            with open("./user_file/"+recv_str.split(",")[1]+'.txt',encoding="utf-8") as f:
                lines = f.readlines()
            with open("./user_file/"+recv_str.split(",")[1]+'.txt',"w",encoding="utf-8") as f_w:
                print("dele:",recv_str.split(",")[2])
                for line in lines:
                    print(line)
                    if recv_str.split(",")[2] in line:
                        continue
                    f_w.write(line)
            print(lines)
        return True

async def send_msg(websocket,response_msg):
    while True:
        await websocket.send(response_msg)
async def main_logic(websocket, path):
    await check_permit(websocket)



start_server = websockets.serve(main_logic, '172.18.95.248', 623)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()

