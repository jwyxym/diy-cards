--绝望之玛莉龙忒 妮德霍格
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
	aux.AddFusionProcFun2(c,this.matfilter1,this.matfilter2,true)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(this.distg)
	e1:SetOperation(this.disop)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+1)
	e1:SetCondition(this.chcon)
	e1:SetTarget(this.chtg)
	e1:SetOperation(this.chop)
	c:RegisterEffect(e1)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,id+2)
	e5:SetCondition(this.pencon)
	e5:SetTarget(this.pentg)
	e5:SetOperation(this.penop)
	c:RegisterEffect(e5)
end
this.material_type=TYPE_SYNCHRO
function this.matfilter1(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_PENDULUM)
end
function this.matfilter2(c)
	return c:IsRace(RACE_DRAGON) and (c:IsFusionType(TYPE_FUSION) or c:IsFusionType(TYPE_SYNCHRO) or c:IsFusionType(TYPE_XYZ))
end
function this.disfilter(c)
	return c:GetBaseAttack()<=3000 and aux.NegateMonsterFilter(c)
end
function this.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(this.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetTargetCard(g)
end
function this.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(this.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
	Duel.BreakEffect()
	Duel.Destroy(c,REASON_EFFECT)
end
function this.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function this.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg1=Duel.GetDecktopGroup(tp,1)
	local tg2=Duel.GetDecktopGroup(1-tp,1)
	if chk==0 then return tg1:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==1 and tg2:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==1 end
end
function this.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,this.repop)
end
function this.repop(e,tp,eg,ep,ev,re,r,rp)
	local tg1=Duel.GetDecktopGroup(tp,1)
	local tg2=Duel.GetDecktopGroup(1-tp,1)
	tg1:Merge(tg2)
	if tg1:GetCount()==0 then return end
	Duel.DisableShuffleCheck()
	Duel.Remove(tg1,POS_FACEDOWN,REASON_EFFECT)
end
function this.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function this.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function this.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
