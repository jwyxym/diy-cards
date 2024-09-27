--[[
Author: EndOfFuture liuyufan981@163.com
Date: 2024-02-26 20:24:29
LastEditors: EndOfFuture liuyufan981@163.com
LastEditTime: 2024-03-02 18:29:42
FilePath: \undefinedd:\Games\KPro\expansions\script\c21300225.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
--晨跃 追光
local this,id,ofs=GetID()
function this.initial_effect(c)
    aux.AddLinkProcedure(c,this.matfilter,2,2,this.matcheck)
    c:EnableReviveLimit()
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(this.con)
    e2:SetTarget(this.tg)
    e2:SetOperation(this.op)
    c:RegisterEffect(e2)
end
function this.matfilter(c)
    return c:IsLinkRace(RACE_CYBERSE)
end
function this.matcheck(g)
    return g:IsExists(Card.IsSetCard,1,nil,0x677)
end
function this.filter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function this.con(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_EXTRA,0,1,nil,tp)
        and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
    if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) )then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,this.filter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
    Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(this.limittg)
	e1:SetValue(this.fuslimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e2:SetTargetRange(LOCATION_GRAVE,0)
	--e2:SetCountLimit(1,id+1)
	e2:SetTarget(this.mttg)
	e2:SetValue(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function this.limittg(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
function this.fuslimit(e,c,sumtype)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
function this.mttg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
