--淬铁龙匠 龙人工匠
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--破坏
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--放置
   	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o*10000)
    e2:SetCondition(s.pencon)
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)     
	--放置
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,31290183)
    e3:SetCondition(s.lgcon)
	e3:SetTarget(s.lgtg)
	e3:SetOperation(s.lgop)
	c:RegisterEffect(e3)    
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.Destroy(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() 
    	and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.BreakEffect()
        if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
        	local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(800)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)			
			c:RegisterEffect(e1)
        end
        Duel.SpecialSummonComplete()
	end
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetAttack()>c:GetBaseAttack() or c:GetDefense()>c:GetBaseDefense()
end    
function s.penfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xcca1) and not c:IsForbidden()
    	and (c:IsFaceup() or c:IsLocation(LOCATION_DECK))
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.confilter(c)
	return c:IsFaceup() and (c:GetOriginalType()&(TYPE_PENDULUM|TYPE_MONSTER)==TYPE_PENDULUM|TYPE_MONSTER or c:IsSetCard(0xcca1))
end
function s.lgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.lgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.lgop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end