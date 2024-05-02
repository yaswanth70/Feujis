AWSTemplateFormatVersion: '2024-05-02'
Description: Create a VPC with public and private subnets

Parameters:
  VpcCIDR:
    Type: String
    Default: "10.0.0.0/16"
    Description: CIDR block for the VPC

Resources:
  MyVPC1:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR

  MyInternetGateway:
    Type: AWS::EC2::InternetGateway

  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref MyVPC1
      InternetGatewayId: !Ref MyInternetGateway

  PublicSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC1
      CidrBlock: !Select [0, !Cidr [!Ref VpcCIDR, 8, 8]]
      AvailabilityZone: !Select [0, !GetAZs !Ref "AWS::Region"]
      MapPublicIpOnLaunch: true

  PrivateSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC1
      CidrBlock: !Select [1, !Cidr [!Ref VpcCIDR, 8, 8]]
      AvailabilityZone: !GetAtt PublicSubnet.AvailabilityZone

Outputs:
  PublicSubnetId:
    Description: Subnet ID of the public subnet
    Value: !Ref PublicSubnet

  PrivateSubnetId:
    Description: Subnet ID of the private subnet
    Value: !Ref PrivateSubnet
