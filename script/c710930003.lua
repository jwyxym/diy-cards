--戮星者·洛尔瓦
local s,id=GetID()

function s.initial_effect(c)

	--① 特殊召唤并装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--② 去除装备怪兽并处理超量怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_EQUIP+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.rmcon)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)

	--③ 攻击力提升
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)

end


----------------------------------------
--①
----------------------------------------

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) 
		or Duel.IsTurnPlayer(1-tp)
end


function s.spfilter(c,tp)
	return (c:IsSetCard(0xc71f) and c:IsMonster())
		or c:IsType(TYPE_XYZ)
end


function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)

	if chk==0 then
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp)
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end


function s.spop(e,tp,eg,ep,ev,re,r,rp)

	local c=e:GetHandler()

	if not c:IsRelateToEffect(e) then return end

	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then

		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,tp)

		if #g>0 then

			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local tc=g:Select(tp,1,1,nil):GetFirst()

			if tc then
				Duel.Equip(tp,tc,c)

				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(TYPE_EQUIP+TYPE_SPELL)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)

			end
		end
	end
end



----------------------------------------
--②
----------------------------------------

--超量怪兽效果发动
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)

	return re:GetHandler():IsType(TYPE_XYZ)
		and e:GetHandler():GetEquipGroup():IsExists(Card.IsMonster,1,nil)

end


--选择装备怪兽送墓
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)

	if chk==0 then
		return e:GetHandler():GetEquipGroup():IsExists(Card.IsMonster,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)

	local g=e:GetHandler():GetEquipGroup():Filter(Card.IsMonster,nil)

	local tc=g:Select(tp,1,1,nil):GetFirst()

	Duel.SendtoGrave(tc,REASON_COST)

	e:SetLabelObject(tc)
end



function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)

	local tc=re:GetHandler()

	if chk==0 then
		return tc:IsType(TYPE_XYZ)
	end

	Duel.SetOperationInfo(0,CATEGORY_TODECK,tc:GetOverlayGroup(),#tc:GetOverlayGroup(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,tc,1,0,0)

end



function s.rmop(e,tp,eg,ep,ev,re,r,rp)

	local tc=re:GetHandler()

	if not tc:IsRelateToEffect(e) then return end


	--超量素材回卡组
	local og=tc:GetOverlayGroup()

	if #og>0 then
		Duel.SendtoDeck(og,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end


	--超量怪兽装备给发动效果的怪兽
	local target=e:GetHandler()

	if tc:IsRelateToEffect(e) and target:IsFaceup() then

		Duel.Equip(tp,tc,target)

		local e1=Effect.CreateEffect(target)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_EQUIP+TYPE_SPELL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)

	end
end



----------------------------------------
--③
----------------------------------------

function s.atkval(e,c)

	local g=c:GetEquipGroup():Filter(Card.IsType,nil,TYPE_XYZ)

	local sum=0

	for tc in aux.Next(g) do
		sum=sum+tc:GetRank()
	end

	return sum*100
end