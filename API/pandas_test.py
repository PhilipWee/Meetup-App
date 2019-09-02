import pandas

test = pandas.read_excel('./Book.xlsx')
print(test)

unique_users = ['stephen','julia','philip']
locations = ['curry','fish']

for user in unique_users:
    for location in locations:
        df = test[test['user'] == user][test['location'] == location]
        print(df)