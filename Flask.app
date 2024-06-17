from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///crm.db'
db.init_app(app)

@app.route('/customers', methods=['POST'])
def add_customer():
    data = request.json
    new_customer = Customer(name=data['name'], email=data['email'], phone=data.get('phone'), address=data.get('address'))
    db.session.add(new_customer)
    db.session.commit()
    return jsonify({'id': new_customer.id}), 201

@app.route('/customers', methods=['GET'])
def get_customers():
    customers = Customer.query.all()
    return jsonify([{'id': c.id, 'name': c.name, 'email': c.email, 'phone': c.phone, 'address': c.address} for c in customers])

@app.route('/customers/<int:customer_id>', methods=['PUT'])
def edit_customer(customer_id):
    data = request.json
    customer = Customer.query.get(customer_id)
    if customer:
        customer.name = data.get('name', customer.name)
        customer.email = data.get('email', customer.email)
        customer.phone = data.get('phone', customer.phone)
        customer.address = data.get('address', customer.address)
        db.session.commit()
        return jsonify({'message': 'Customer updated'}), 200
    return jsonify({'message': 'Customer not found'}), 404

@app.route('/customers/<int:customer_id>', methods=['DELETE'])
def delete_customer(customer_id):
    customer = Customer.query.get(customer_id)
    if customer:
        db.session.delete(customer)
        db.session.commit()
        return jsonify({'message': 'Customer deleted'}), 200
    return jsonify({'message': 'Customer not found'}), 404

@app.route('/interactions', methods=['POST'])
def log_interaction():
    data = request.json
    new_interaction = Interaction(customer_id=data['customer_id'], type=data['type'], notes=data['notes'], date=datetime.strptime(data['date'], '%Y-%m-%d %H:%M:%S'))
    db.session.add(new_interaction)
    db.session.commit()
    return jsonify({'id': new_interaction.id}), 201

@app.route('/opportunities', methods=['POST'])
def add_opportunity():
    data = request.json
    new_opportunity = Opportunity(customer_id=data['customer_id'], title=data['title'], description=data.get('description'), stage=data['stage'], value=data['value'])
    db.session.add(new_opportunity)
    db.session.commit()
    return jsonify({'id': new_opportunity.id}), 201

@app.route('/dashboard', methods=['GET'])
def dashboard():
    opportunities_count = Opportunity.query.count()
    interactions_count = Interaction.query.count()
    customers_count = Customer.query.count()
    return jsonify({'opportunities_count': opportunities_count, 'interactions_count': interactions_count, 'customers_count': customers_count})

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
