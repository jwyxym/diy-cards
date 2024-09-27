--冬之女王 摩根
local this,id,ofs=GetID()
function this.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,12,3,this.ovfilter,aux.Stringid(id,0),3,this.xyzop)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(this.setcon)
	e2:SetTarget(this.settg)
	e2:SetOperation(this.setop)
	c:RegisterEffect(e2)
	aux.EnableChangeCode(c,76200305,LOCATION_ONFIELD)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(this.imcon)
	e3:SetValue(this.efilter)
	c:RegisterEffect(e3)
	if not this.global_check then
		this.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(this.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function this.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsLevel(12)
end
function this.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)>0 and Duel.GetFlagEffect(tp,id+1)==0 end
	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function this.check(c)
	return c and c:IsRace(RACE_SPELLCASTER)
end
function this.checkop(e,tp,eg,ep,ev,re,r,rp)
	if this.check(Duel.GetAttacker()) or this.check(Duel.GetAttackTarget()) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
function this.filter(c)
	return c:IsCode(76200360) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function this.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function this.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_DECK,0,1,nil) end
end
function this.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,this.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
        Duel.SSet(tp,tc)
	end
end
function this.imfilter(c)
    return c:IsCode(76200306) and c:IsFaceup()
end
function this.imcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(this.imfilter,tp,LOCATION_SZONE,0,nil)>=1
end
function this.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
