--伊瑟拉（兼容所有龙群先锋）
local s,id=GetID()
function s.initial_effect(c)
	if aux.AddCodeList then aux.AddCodeList(c,id) end

	-- 超量召唤手续（硬编码支持树妖、姐妹、龙群先锋）
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.xyzcon)
	e1:SetOperation(s.xyzop)
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)

	-- ① 无效并破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	-- ② 吸收魔法卡 + 选破（已修复规则送墓）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.abscon)
	e3:SetTarget(s.abstg)
	e3:SetOperation(s.absop)
	c:RegisterEffect(e3)
end

-- ===== 超量素材 =====
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsFaceup()
		and (c:IsLevel(9) or c:IsCode(44990103) or c:IsCode(44990105) or c:IsCode(44990108))
end
function s.mlvl(c)
	if c:IsCode(44990103) or c:IsCode(44990105) or c:IsCode(44990108) then return 9 end
	return c:GetLevel()
end
function s.mcheck(g)
	if #g~=2 then return false end
	local sum=0
	for tc in aux.Next(g) do
		sum=sum+s.mlvl(tc)
	end
	return sum==18
end
function s.xyzcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return false end
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(s.mcheck,2,2)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local sg=g:SelectSubGroup(tp,s.mcheck,true,2,2)
	if sg and #sg==2 then
		Duel.Overlay(c,sg)
	end
end

-- ===== ① 无效并破坏 =====
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_SPELL)
		and Duel.GetFlagEffect(tp,id)==0
		and Duel.IsChainDisablable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		local tc=re:GetHandler()
		if tc and tc:IsRelateToEffect(re) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end

-- ===== ② 吸收魔法卡 + 选破 =====
function s.abscon(e,tp,eg,ep,ev,re,r,rp)
	if not (ep==tp and re:IsActiveType(TYPE_SPELL) and Duel.GetFlagEffect(tp,id+100)==0) then return false end
	local rc=re:GetHandler()
	if rc:IsCode(id) then return false end
	if aux.IsCodeListed then
		return aux.IsCodeListed(rc,id)
	else
		return rc:IsSetCard(0xcf1)
	end
end
function s.abstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.absop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	if not tc or not tc:IsRelateToEffect(re) then return end
	if not tc:IsLocation(LOCATION_SZONE) then return end

	tc:CancelToGrave()
	Duel.Overlay(c,Group.FromCards(tc))

	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_CARD)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
end