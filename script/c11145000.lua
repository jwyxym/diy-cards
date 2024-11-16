--七情世界
function c11145000.initial_effect(c)
	aux.AddCodeList(c,11145001)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11145000,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,11145000)
	e2:SetTarget(c11145000.drtg)
	e2:SetOperation(c11145000.drop)
	c:RegisterEffect(e2)
	--Recover
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(11145000,1))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetTarget(c11145000.rectg)
	e3:SetOperation(c11145000.recop)
	c:RegisterEffect(e3)
	--Damage
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(11145000,2))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetTarget(c11145000.damctg)
	e4:SetOperation(c11145000.damcop)
	c:RegisterEffect(e4)
	--field
	local e5=e2:Clone()
	e5:SetDescription(aux.Stringid(11145000,3))
	e5:SetTarget(c11145000.fdtg)
	e5:SetOperation(c11145000.fdop)
	c:RegisterEffect(e5)
	--field2
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(11145000,4))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1,11145000+1000)
	e6:SetCondition(c11145000.fdcon)
	e6:SetTarget(c11145000.fdtg2)
	e6:SetOperation(c11145000.fdop2)
	c:RegisterEffect(e6)
	--Damage2
	local e7=e6:Clone()
	e7:SetDescription(aux.Stringid(11145000,5))
	e7:SetCategory(CATEGORY_DAMAGE)
	e7:SetCondition(c11145000.damcon)
	e7:SetTarget(c11145000.damtg2)
	e7:SetOperation(c11145000.damop2)
	c:RegisterEffect(e7)
	--Draw2
	local e8=e6:Clone()
	e8:SetDescription(aux.Stringid(11145000,6))
	e8:SetCategory(CATEGORY_DRAW)
	e8:SetCondition(c11145000.drcon)
	e8:SetTarget(c11145000.drtg2)
	e8:SetOperation(c11145000.drop2)
	c:RegisterEffect(e8)
end
function c11145000.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function c11145000.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
function c11145000.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,1000)
end
function c11145000.recop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(tp,1000,REASON_EFFECT)
	Duel.Recover(1-tp,1000,REASON_EFFECT)
end
function c11145000.damctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
function c11145000.damcop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,1000,REASON_EFFECT)
	Duel.Damage(1-tp,1000,REASON_EFFECT)
end
function c11145000.setfilter(c,tp)
	return c:IsCode(11145001) and not c:IsForbidden()
end
function c11145000.fdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11145000.setfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function c11145000.fdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,c11145000.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
function c11145000.setfilter2(c,tp)
	return c:IsCode(11145001) and not c:IsForbidden()
end
function c11145000.fdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function c11145000.fdtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11145000.setfilter2,tp,LOCATION_DECK,0,1,nil,tp) end
end
function c11145000.fdop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,c11145000.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
function c11145000.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function c11145000.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
function c11145000.damop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,1500,REASON_EFFECT)
end
function c11145000.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function c11145000.drtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end	
function c11145000.drop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end



