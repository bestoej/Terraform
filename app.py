from flask import Flask, request, jsonify

app = Flask(__name__)

# Endpoint 1: Hello Endpoint
@app.route('/hello', methods=['GET'])
def hello():
    return jsonify(message="Hello, Welcome to the API Mannan !")

# Endpoint 2: Sum Endpoint
@app.route('/sum', methods=['GET'])
def calculate_sum():
    # Get parameters from request
    num1 = request.args.get('num1', type=float)
    num2 = request.args.get('num2', type=float)
    
    if num1 is None or num2 is None:
        return jsonify(error="Please provide two numbers as 'num1' and 'num2' query parameters."), 400
    
    result = num1 + num2
    return jsonify(num1=num1, num2=num2, sum=result)

# Run the app
if __name__ == '__main__':
    app.run(debug=True)
