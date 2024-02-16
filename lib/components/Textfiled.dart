import 'package:flutter/material.dart';
    class MyTextField extends StatelessWidget {
      final Controller;
      final String hintText;
      final String labelText;
      final bool obsecureText;
      final Icon icon;
     MyTextField({required this.hintText,required this.labelText, this.Controller,required this.obsecureText, required this.icon});

      @override
      Widget build(BuildContext context) {
        return TextField(
          controller: Controller,
          obscureText: obsecureText,
          decoration: InputDecoration(
            iconColor: Color.fromARGB(255, 32, 67, 170),
            filled: true,
            fillColor: Colors.white,
            focusColor: Colors.black,
            prefixIcon: icon ,prefixIconColor: Color.fromARGB(255, 32, 67, 170),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(80),
              borderSide: BorderSide(width: 3,color: Color.fromARGB(255, 32, 67, 170),)


            ),
            labelText: labelText,
            hintText: hintText,hintStyle:TextStyle(color: Colors.black87,)

          ),


        );
      }
    }
    