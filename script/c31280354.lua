--暗黑破壞的创造物
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280355)
    aux.EnablePendulumAttribute(c,false)
	--同调召唤    
	aux.AddXyzProcedure(c,nil,10,3)
	c:EnableReviveLimit()
	--怪兽效破耐性    
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--破坏    
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY+CATEGORY_TODECK+CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--效破耐性    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--原本攻击力
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_BASE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)    
	--放置    
    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(s.setcon)
	e5:SetTarget(s.settg)
	e5:SetOperation(s.setop)
	c:RegisterEffect(e5)
end
function s.efilter(e,re,rp)
	return re:IsActiveType(TYPE_EFFECT)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(31280355)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler()) and tp==Duel.GetTurnPlayer()
end
function s.damval1(c)
	if c:GetLocation()~=LOCATION_MZONE then return end
	return math.max(0,c:GetTextAttack())
end
function s.damval2(c)
	if c:GetPreviousLocation()~=LOCATION_MZONE then return end
	return math.max(0,c:GetTextAttack())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
    local tg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOEXTRA+CATEGORY_TODECK,tg,tg:GetCount(),0,0)
	local atk=g:GetSum(s.damval1)
	if atk>0 then 
    	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0) 
    end    
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		local dg=Duel.GetOperatedGroup()
		local atk=dg:GetSum(s.damval2)
		if atk>0 and Duel.Damage(1-tp,atk,REASON_EFFECT) then
        	local tg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
            if tg:GetCount()==0 then return end
        	Duel.BreakEffect()
            Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)
		end
	end
end
function s.atkval(e,c)
	return e:GetHandler():GetOverlayCount()*800
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end