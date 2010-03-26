require File.dirname(__FILE__) + "/../spec_helper"

import "java_integration.fixtures.ClassWithEnums"
import "java_integration.fixtures.JavaFields"
import "java_integration.fixtures.InnerClasses"

describe "Java::JavaClass.for_name" do
  it "should return primitive classes for Java primitive type names" do
    Java::JavaClass.for_name("byte").should == Java::byte.java_class
    Java::JavaClass.for_name("boolean").should == Java::boolean.java_class
    Java::JavaClass.for_name("short").should == Java::short.java_class
    Java::JavaClass.for_name("char").should == Java::char.java_class
    Java::JavaClass.for_name("int").should == Java::int.java_class
    Java::JavaClass.for_name("long").should == Java::long.java_class
    Java::JavaClass.for_name("float").should == Java::float.java_class
    Java::JavaClass.for_name("double").should == Java::double.java_class
  end
end

describe "Java classes with nested enums" do
  it "should allow access to the values() method on the enum" do
    ClassWithEnums::Enums.values.map{|e|e.to_s}.should == ["A", "B", "C"];
  end
end

describe "A Java class" do
  describe "in a package with a leading underscore" do
    it "can be accessed directly using the Java:: prefix" do
      myclass = Java::java_integration.fixtures._funky.MyClass
      myclass.new.foo.should == "MyClass"
    end
  end
end

describe "A JavaClass wrapper around a java.lang.Class" do
  it "provides a nice String output for inspect" do
    myclass = java.lang.String.java_class
    myclass.inspect.should == "class java.lang.String"
  end
end

describe "A JavaClass with fields containing leading and trailing $" do
  it "should be accessible" do
    JavaFields.send('$LEADING').should == "leading"
    JavaFields.send('TRAILING$').should == true
  end
end

describe "A Java class with inner classes" do
  it "should define constants for constantable classes" do
    InnerClasses.constants.should include 'CapsInnerClass'
    InnerClasses::CapsInnerClass.value.should == 1
    
    InnerClasses::CapsInnerClass.constants.should include "CapsInnerClass2"
    InnerClasses::CapsInnerClass::CapsInnerClass2.value.should == 1
    
    InnerClasses::CapsInnerClass.constants.should include "CapsInnerInterface2"
    
    InnerClasses::CapsInnerClass.constants.should_not include 'lowerInnerClass2'
    InnerClasses::CapsInnerClass.constants.should_not include 'lowerInnerInterface2'

    InnerClasses.constants.should include 'CapsInnerInterface'

    InnerClasses::CapsInnerInterface.constants.should include "CapsInnerClass4"
    InnerClasses::CapsInnerInterface::CapsInnerClass4.value.should == 1

    InnerClasses::CapsInnerInterface.constants.should include "CapsInnerInterface4"

    InnerClasses::CapsInnerInterface.constants.should_not include 'lowerInnerClass4'
    InnerClasses::CapsInnerInterface.constants.should_not include 'lowerInnerInterface4'
  end

  it "should define methods for lower-case classes" do
    InnerClasses.methods.should include 'lowerInnerClass'
    InnerClasses::lowerInnerClass.value.should == 1
    InnerClasses.lowerInnerClass.value.should == 1
    InnerClasses.lowerInnerClass.should == InnerClasses::lowerInnerClass

    InnerClasses.lowerInnerClass.constants.should include 'CapsInnerClass3'
    InnerClasses.lowerInnerClass.constants.should include 'CapsInnerInterface3'

    InnerClasses.lowerInnerClass::CapsInnerClass3.value.should == 1

    InnerClasses.lowerInnerClass.methods.should include 'lowerInnerInterface3'
    InnerClasses.lowerInnerClass.methods.should include 'lowerInnerClass3'
    
    InnerClasses.lowerInnerClass::lowerInnerClass3.value.should == 1
    InnerClasses.lowerInnerClass.lowerInnerClass3.value.should == 1

    InnerClasses.methods.should include 'lowerInnerInterface'
    InnerClasses.lowerInnerInterface.should == InnerClasses::lowerInnerInterface

    InnerClasses.lowerInnerInterface.constants.should include 'CapsInnerClass5'
    InnerClasses.lowerInnerInterface.constants.should include 'CapsInnerInterface5'

    InnerClasses.lowerInnerInterface::CapsInnerClass5.value.should == 1
    
    InnerClasses.lowerInnerInterface.methods.should include 'lowerInnerInterface5'
    InnerClasses.lowerInnerInterface.methods.should include 'lowerInnerClass5'
    
    InnerClasses.lowerInnerInterface::lowerInnerClass5.value.should == 1
    InnerClasses.lowerInnerInterface.lowerInnerClass5.value.should == 1
  end

  it "raises error importing lower-case names" do
    lambda do
      java_import InnerClasses::lowerInnerClass
    end.should raise_error(ArgumentError)
  end

  it "imports upper-case names successfully" do
    lambda do
      java_import InnerClasses::CapsInnerClass
    end.should_not raise_error
    CapsInnerClass.should == InnerClasses::CapsInnerClass
  end
end
