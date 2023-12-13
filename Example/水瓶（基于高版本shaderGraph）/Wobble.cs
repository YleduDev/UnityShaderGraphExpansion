using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
public class Wobble : MonoBehaviour
{
    Renderer render;
    Vector3 lastPos;
    Vector3 velocity;
    Vector3 lastRot;  
    Vector3 angularVelocity;
    public float MaxWobble = 0.03f;
    public float WobbleSpeed = 1f;
    public float Recovery = 1f;
    float wobbleAmountX;
    float wobbleAmountZ;
    float wobbleAmountToAddX;
    float wobbleAmountToAddZ;
    float pulse;
    float time = 0.5f;
    public Material mat;
    private MaterialPropertyBlock materialPropertyBlock;

    void Start()
    {
        render = GetComponent<Renderer>();
        materialPropertyBlock = new MaterialPropertyBlock();
    }

    private void Update()
    {
        if(render == null)
        {
            return;
        }
        
        time += Time.deltaTime;

        // decrease wobble over time
        wobbleAmountToAddX = Mathf.Lerp(wobbleAmountToAddX, 0, Time.deltaTime * (Recovery));
        wobbleAmountToAddZ = Mathf.Lerp(wobbleAmountToAddZ, 0, Time.deltaTime * (Recovery));
 
        // make a sine wave of the decreasing wobble
        pulse = 2 * Mathf.PI * WobbleSpeed;
        wobbleAmountX = wobbleAmountToAddX * Mathf.Sin(pulse * time);
        wobbleAmountZ = wobbleAmountToAddZ * Mathf.Sin(pulse * time);
 
        // send it to the shader
        materialPropertyBlock.SetFloat("_WobbleX", wobbleAmountX);
        materialPropertyBlock.SetFloat("_WobbleZ", wobbleAmountZ);
        render.SetPropertyBlock(materialPropertyBlock);

        if(mat!=null)
        {
            mat.SetFloat("_WobbleX", wobbleAmountX);
            mat.SetFloat("_WobbleZ", wobbleAmountZ);
        }
 
        // velocity
        velocity = (lastPos - transform.position) / Time.deltaTime;
        angularVelocity = transform.rotation.eulerAngles - lastRot;
 
        // add clamped velocity to wobble
        wobbleAmountToAddX += Mathf.Clamp((velocity.x + (angularVelocity.z * 0.2f)) * MaxWobble, -MaxWobble, MaxWobble);
        wobbleAmountToAddZ += Mathf.Clamp((velocity.z + (angularVelocity.x * 0.2f)) * MaxWobble, -MaxWobble, MaxWobble);

        wobbleAmountToAddZ += Mathf.Clamp((velocity.y + (angularVelocity.y * 0.2f)) * MaxWobble, -MaxWobble, MaxWobble);
        wobbleAmountToAddX += Mathf.Clamp((velocity.y + (angularVelocity.y * 0.2f)) * MaxWobble, -MaxWobble, MaxWobble);

        // keep last position
        lastPos = transform.position;
        lastRot = transform.rotation.eulerAngles;
    }
}

