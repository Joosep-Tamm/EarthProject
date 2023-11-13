using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement : MonoBehaviour
{
    public float moveSpeed = 5f;         // Adjust this speed as needed.
    public float rotationSpeed = 180f;   // Adjust this speed as needed.

    void Update()
    {
        // Movement
        float horizontalInput = Input.GetAxis("Horizontal");
        float verticalInput = Input.GetAxis("Vertical");
        Vector3 movement = new Vector3(horizontalInput, 0f, verticalInput) * moveSpeed * Time.deltaTime;
        transform.Translate(movement);

        // Rotation
        float horizontalRotationInput = Input.GetAxis("HorizontalRotation");
        float verticalRotationInput = Input.GetAxis("VerticalRotation");
        Vector3 rotation = new Vector3(verticalRotationInput, horizontalRotationInput, 0f) * rotationSpeed * Time.deltaTime;
        transform.Rotate(rotation);
    }
}
