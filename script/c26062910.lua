-- 优雅的呐喊 速攻魔法
-- ID: 26062910
-- 记述「春日影」(26062911)
-- 此卡自身不持有“丰川祥子”(0x951)字段
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,26062911)  -- 声明记述「春日影」

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	local b2=Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local ops={}
	if b1 then table.insert(ops,aux.Stringid(id,1)) end
	if b2 then table.insert(ops,aux.Stringid(id,2)) end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	e:SetLabel(op+1)
	if op==0 and b1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
	if op==1 and b2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_MZONE)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		local tc=Duel.GetFirstTarget()
		if not tc:IsRelateToEffect(e) then return end
		local b1=tc:IsAbleToHand()
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		if b1 and b2 then
			local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
			if op==0 then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			else
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif b1 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		elseif b2 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif sel==2 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)~=0 then
			if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
				and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
				local dg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
				if #dg>0 then
					Duel.Destroy(dg,REASON_EFFECT)
				end
			end
		end
	end
end

-- 效果1对象：自己墓地的记述「春日影」怪兽
function s.filter1(c,e,tp)
	return aux.IsCodeListed(c,26062911) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end

-- 效果2对象：自己场上的“丰川祥子”怪兽 (0x951)
function s.filter2(c)
	return c:IsSetCard(0x951) and c:IsFaceup()
end