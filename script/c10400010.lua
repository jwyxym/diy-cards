--痛苦司命 巴浊
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(this.splimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(this.damval)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(this.immfilter)
	c:RegisterEffect(e4)
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(this.sucop)
	c:RegisterEffect(e3)
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_TODECK)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_PHASE+PHASE_END)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(this.tdcon)
    e5:SetTarget(this.tdtg)
    e5:SetOperation(this.tdop)
    c:RegisterEffect(e5)
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_ATTACK_FINAL)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE,EFFECT_FLAG2_WICKED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(this.adval)
	c:RegisterEffect(e4)
    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e6:SetValue(1)
	e6:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e7)
end
function this.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(10400040)
end
function this.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return val*2 end
	return val
end
function this.immfilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function this.sucop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local ph=Duel.GetCurrentPhase()
    if Duel.GetTurnPlayer()==1-tp and ph==PHASE_END then
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,2)
    else
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
    end
end
function this.tdcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)>0 and ep==1-tp
end
function this.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToExtra() end
    Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
function this.tdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT) end
end
function this.adval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tg,val=g:GetMaxGroup(Card.GetAttack)
	return val
end
