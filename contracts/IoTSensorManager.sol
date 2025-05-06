// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract manages IoT sensors by allowing the creation, retrieval, and updating of sensor data.
contract IoTSensorManager {
    // Define a structure to represent a sensor.
    struct Sensor {
        string id;        // Unique identifier for the sensor
        string location;  // Physical or logical location of the sensor
        string dataType;  // Type of data the sensor collects (e.g., temperature, humidity)
        string data;      // Current data collected by the sensor
    }

    // Mapping from sensor ID to Sensor structure
    // This allows us to store and retrieve sensor information using the sensor ID as the key.
    mapping(string => Sensor) private sensors;

    // Create a new sensor
    // Parameters:
    // - _id: Unique identifier for the sensor
    // - _location: Location of the sensor
    // - _dataType: Type of data the sensor collects
    function createSensor(
        string memory _id,       // Unique identifier for the sensor
        string memory _location, // Physical or logical location of the sensor
        string memory _dataType  // Type of data the sensor collects (e.g., temperature, humidity)
    ) public {
        // Ensure that a sensor with the given ID does not already exist.
        require(bytes(sensors[_id].id).length == 0, "Sensor already exists");
        // Add the new sensor to the mapping with an empty data field.
        sensors[_id] = Sensor(_id, _location, _dataType, "");
    }

    // Function to read the details of a sensor.
    // Parameters:
    // - _id: Unique identifier of the sensor to retrieve
    // Returns:
    // - id: The sensor's unique identifier
    // - location: The sensor's location
    // - dataType: The type of data the sensor collects
    // - data: The current data stored in the sensor
    function readSensor(string memory _id)
        public
        view
        returns (
            string memory id,
            string memory location,
            string memory dataType,
            string memory data
        )
    {
        // Ensure that the sensor with the given ID exists.
        require(bytes(sensors[_id].id).length != 0, "Sensor does not exist");

        // Retrieve the sensor from the mapping.
        Sensor memory sensor = sensors[_id];

        // Return the sensor's details.
        return (sensor.id, sensor.location, sensor.dataType, sensor.data);
    }

    // Function to update the data of an existing sensor.
    // Parameters:
    // - _id: Unique identifier of the sensor to update
    // - _data: New data to store in the sensor
    function updateSensorData(string memory _id, string memory _data) public {
        // Ensure that the sensor with the given ID exists.
        require(bytes(sensors[_id].id).length != 0, "Sensor does not exist");

        // Update the sensor's data field with the new data.
        sensors[_id].data = _data;
    }

    // Variable to store the cost per sensor after the third sensor
    uint256 public sensorCost = 0.01 ether;

    // Mapping to track the number of sensors created by each address
    mapping(address => uint256) private sensorCount;

    // Function to set the cost per sensor (only owner can call this)
    function setSensorCost(uint256 _cost) public {
        sensorCost = _cost;
    }

    // Modified createSensor function to include payment logic
    function createSensorWithPayment(
        string memory _id,
        string memory _location,
        string memory _dataType
    ) public payable {
        // Ensure that a sensor with the given ID does not already exist.
        require(bytes(sensors[_id].id).length == 0, "Sensor already exists");

        // Check if the sender has already created more than three sensors
        if (sensorCount[msg.sender] >= 3) {
            require(msg.value >= sensorCost, "Insufficient payment for sensor creation");
        }

        // Add the new sensor to the mapping with an empty data field.
        sensors[_id] = Sensor(_id, _location, _dataType, "");

        // Increment the sensor count for the sender
        sensorCount[msg.sender]++;
    }

    // Function to withdraw collected payments (only owner can call this)
    function withdrawPayments(address payable _to) public {
        _to.transfer(address(this).balance);
    }

    // Mapping to track the number of data transmissions for each sensor
    mapping(string => uint256) private dataTransmissionCount;

    // Mapping to track the accumulated fees for each sensor
    mapping(string => uint256) private accumulatedFees;

    // Fee per data transmission
    uint256 public dataTransmissionFee = 0.001 ether;

    // Function to set the data transmission fee (only owner can call this)
    function setDataTransmissionFee(uint256 _fee) public {
        dataTransmissionFee = _fee;
    }

    // Function to record a data transmission and accumulate fees
    function recordDataTransmission(string memory _id) public payable {
        // Ensure that the sensor with the given ID exists
        require(bytes(sensors[_id].id).length != 0, "Sensor does not exist");

        // Ensure the sender has paid the required fee
        require(msg.value >= dataTransmissionFee, "Insufficient payment for data transmission");

        // Increment the data transmission count for the sensor
        dataTransmissionCount[_id]++;

        // Accumulate the fee for the sensor
        accumulatedFees[_id] += msg.value;

        // If the sensor has reached 10 transmissions, reset the count
        if (dataTransmissionCount[_id] >= 10) {
            dataTransmissionCount[_id] = 0;
        }
    }

    // Function to withdraw accumulated fees for a specific sensor (only owner can call this)
    function withdrawSensorFees(string memory _id, address payable _to) public {
        // Ensure that the sensor with the given ID exists
        require(bytes(sensors[_id].id).length != 0, "Sensor does not exist");

        // Get the accumulated fees for the sensor
        uint256 fees = accumulatedFees[_id];

        // Ensure there are fees to withdraw
        require(fees > 0, "No fees to withdraw");

        // Reset the accumulated fees for the sensor
        accumulatedFees[_id] = 0;

        // Transfer the fees to the specified address
        _to.transfer(fees);
    }
}
