import requests

# URL and authentication details
url = 'http://localhost:8080/ViewDefinition/'
auth = ('basic', 'secret')

# Read the YAML file
with open('view_request.yaml', 'r') as file:
    data = file.read()

# Set the headers
headers = {
    'Content-Type': 'application/yaml'
}


# Make the POST request
response = requests.post(url, headers=headers, data=data, auth=auth)

# Print the response
print(response.status_code)
print(response.text)