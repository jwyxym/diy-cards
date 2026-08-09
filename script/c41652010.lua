-- 苦土
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,41652000)
	--effect
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SUMMON)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(2,id)
	e0:SetCost(s.effcost)
	e0:SetTarget(s.efftg)
	e0:SetOperation(s.effop)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.effcost2)
	e1:SetTarget(s.efftg2)
	e1:SetOperation(s.effop2)
	c:RegisterEffect(e1)
	local e2=e0:Clone()
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(s.effcost2)
	e2:SetTarget(s.efftg2)
	e2:SetOperation(s.effop3)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp)
	return aux.IsCodeOrListed(c,41652000) and c:IsType(TYPE_MONSTER) or not c:IsControler(tp)
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,c,tp)
	if Duel.IsPlayerAffectedByEffect(tp,41652045) then
		local cg=Duel.GetDecktopGroup(1-tp,1)
		g:Merge(cg)
	end
	if chk==0 then return g:GetCount()>0 and Duel.GetFlagEffect(tp,id+1000)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=g:Select(tp,1,1,c):GetFirst()
	local cg=Group.CreateGroup()
	if tc:IsLocation(LOCATION_HAND) then
		cg:AddCard(tc)
		cg:AddCard(c)
		Duel.ConfirmCards(1-tp,cg)
		e:SetLabel(0)
	elseif tc:IsLocation(LOCATION_ONFIELD) then
		cg:AddCard(tc)
		Duel.HintSelection(cg)
		e:SetLabel(1)
	elseif tc:IsLocation(LOCATION_GRAVE) then
		cg:AddCard(tc)
		Duel.HintSelection(cg)
		e:SetLabel(2)
	elseif tc:IsLocation(LOCATION_DECK) then
		cg:AddCard(tc)
		Duel.HintSelection(cg)
		Duel.DisableShuffleCheck()
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		e:SetLabel(3)
	end
	if tc:IsCode(41652000) then
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	end
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
	Duel.ShuffleHand(tp)
	Duel.RegisterFlagEffect(tp,id+1000,RESET_CHAIN,0,1)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local eff=e:GetLabel()
	local c=e:GetHandler()
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	if eff==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,nil,tp,LOCATION_ONFIELD)
	elseif eff==2 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,nil,tp,LOCATION_GRAVE)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,nil,tp,LOCATION_HAND)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local eff=e:GetLabel()
	local sc=e:GetLabelObject()
	local c=e:GetHandler()
	Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2,true)
	Duel.SpecialSummonComplete()
	if eff==0 then
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e3,true)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetValue(RESET_TURN_SET)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e4,true)
		Duel.SpecialSummonComplete()
	elseif eff==1 then
		if Duel.SendtoGrave(sc,REASON_EFFECT)~=0 and sc:IsLocation(LOCATION_GRAVE) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	elseif eff==2 then
		Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)
	end
	if Duel.GetFlagEffect(tp,id)~=0 then
		if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) then
			Duel.Draw(1-tp,1,REASON_EFFECT)
		elseif Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
function s.effcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,c,tp)
	if Duel.IsPlayerAffectedByEffect(tp,41652045) then
		local cg=Duel.GetDecktopGroup(1-tp,1)
		g:Merge(cg)
	end
	if chk==0 then return g:GetCount()>0 and Duel.GetFlagEffect(tp,id+1000)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=g:Select(tp,1,1,c):GetFirst()
	local cg=Group.CreateGroup()
	if tc:IsLocation(LOCATION_HAND) then
		cg:AddCard(tc)
		Duel.ConfirmCards(1-tp,cg)
		e:SetLabel(0)
		Duel.ShuffleHand(tp)
	elseif tc:IsLocation(LOCATION_ONFIELD) then
		cg:AddCard(tc)
		cg:AddCard(c)
		Duel.HintSelection(cg)
		e:SetLabel(1)
	elseif tc:IsLocation(LOCATION_GRAVE) then
		cg:AddCard(tc)
		Duel.HintSelection(cg)
		e:SetLabel(2)
	elseif tc:IsLocation(LOCATION_DECK) then
		cg:AddCard(tc)
		Duel.HintSelection(cg)
		Duel.DisableShuffleCheck()
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		e:SetLabel(3)
	end
	if tc:IsCode(41652000) then
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	end
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
	Duel.RegisterFlagEffect(tp,id+1000,RESET_CHAIN,0,1)
end
function s.efftg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local eff=e:GetLabel()
	local c=e:GetHandler()
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	if eff==0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,nil,tp,LOCATION_HAND)
	elseif eff==2 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,nil,tp,LOCATION_GRAVE)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,nil,tp,LOCATION_ONFIELD)
end
function s.effop2(e,tp,eg,ep,ev,re,r,rp)
	local eff=e:GetLabel()
	local sc=e:GetLabelObject()
	local c=e:GetHandler()
	if eff==0 then
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2,true)
		Duel.SpecialSummonComplete()
	elseif eff==1 then
		local ct=0
		if Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then ct=ct+1 end
		if Duel.SendtoGrave(sc,REASON_EFFECT)~=0 and sc:IsLocation(LOCATION_GRAVE) then ct=ct+1 end
		if ct>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,ct,nil)
			if #tg>0 then
				Duel.SendtoGrave(tg,REASON_EFFECT)
			end
		end
	elseif eff==2 then
		Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)
	end
	if eff~=1 then
		if Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
			if #tg>0 then
				Duel.SendtoGrave(tg,REASON_EFFECT)
			end
		end
	end
	if Duel.GetFlagEffect(tp,id)~=0 then
		if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) then
			Duel.Draw(1-tp,1,REASON_EFFECT)
		elseif Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
function s.effcost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,c,tp)
	if Duel.IsPlayerAffectedByEffect(tp,41652045) then
		local cg=Duel.GetDecktopGroup(1-tp,1)
		g:Merge(cg)
	end
	if chk==0 then return g:GetCount()>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=g:Select(tp,1,1,c):GetFirst()
	local cg=Group.CreateGroup()
	if tc:IsLocation(LOCATION_HAND) then
		cg:AddCard(tc)
		Duel.ConfirmCards(1-tp,cg)
		e:SetLabel(0)
		Duel.ShuffleHand(tp)
	elseif tc:IsLocation(LOCATION_ONFIELD) then
		cg:AddCard(tc)
		Duel.HintSelection(cg)
		e:SetLabel(1)
	elseif tc:IsLocation(LOCATION_GRAVE) then
		cg:AddCard(tc)
		cg:AddCard(c)
		Duel.HintSelection(cg)
		e:SetLabel(2)
	elseif tc:IsLocation(LOCATION_DECK) then
		cg:AddCard(tc)
		Duel.HintSelection(cg)
		Duel.DisableShuffleCheck()
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		e:SetLabel(3)
	end
	if tc:IsCode(41652000) then
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	end
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
end
function s.efftg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local eff=e:GetLabel()
	local c=e:GetHandler()
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	if eff==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,nil,tp,LOCATION_ONFIELD)
	elseif eff==0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,nil,tp,LOCATION_HAND)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,nil,tp,LOCATION_GRAVE)
end
function s.effop3(e,tp,eg,ep,ev,re,r,rp)
	local eff=e:GetLabel()
	local sc=e:GetLabelObject()
	local c=e:GetHandler()
	Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
	if eff==0 then
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2,true)
		Duel.SpecialSummonComplete()
	elseif eff==1 then
		if Duel.SendtoGrave(sc,REASON_EFFECT)~=0 and sc:IsLocation(LOCATION_GRAVE)  then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	elseif eff==2 then
		Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)
	end
	if Duel.GetFlagEffect(tp,id)~=0 then
		if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) then
			Duel.Draw(1-tp,1,REASON_EFFECT)
		elseif Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end